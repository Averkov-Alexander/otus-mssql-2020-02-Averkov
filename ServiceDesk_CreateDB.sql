USE [ServiceDesk]
GO
/****** Object:  Schema [Application]    Script Date: 16.07.2020 0:54:08 ******/
CREATE SCHEMA [Application]
GO
/****** Object:  Schema [Devices]    Script Date: 16.07.2020 0:54:08 ******/
CREATE SCHEMA [Devices]
GO
/****** Object:  Schema [Incidents]    Script Date: 16.07.2020 0:54:08 ******/
CREATE SCHEMA [Incidents]
GO
/****** Object:  Table [Application].[ContactTypes]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[ContactTypes](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_CONTACTTYPES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Application].[Departments]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[Departments](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DEPARTMENTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Application].[Services]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[Services](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SERVICES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Application].[SLA]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[SLA](
	[ID] [int] NOT NULL,
	[Service] [int] NOT NULL,
	[IncidentType] [int] NOT NULL,
	[ReactionTime] [int] NOT NULL,
	[ExectionTime] [int] NOT NULL,
 CONSTRAINT [PK_sla] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Application].[UserContacts]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[UserContacts](
	[ID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ContactType] [int] NOT NULL,
	[Value] [nvarchar](200) NOT NULL,
	[ValueXML] [xml] NOT NULL,
 CONSTRAINT [PK_USERCONTACTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Application].[Users]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Application].[Users](
	[ID] [int] NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[Department] [int] NOT NULL,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Devices].[DeviceOwners]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Devices].[DeviceOwners](
	[Deivce] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_DEVICEOWNERS] PRIMARY KEY CLUSTERED 
(
	[Deivce] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Devices].[Devices]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Devices].[Devices](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IP_1] [int] NULL,
	[IP_2] [int] NULL,
	[IP_3] [int] NULL,
	[IP_4] [int] NULL,
	[IP]  AS ((((CONVERT([nvarchar](3),[IP_1])+'.')+CONVERT([nvarchar](3),[IP_2]))+'.')+CONVERT([nvarchar](3),[IP_3])) PERSISTED NOT NULL,
	[DeviceType] [int] NOT NULL,
 CONSTRAINT [PK_DEVICES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Devices].[DeviceTypes]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Devices].[DeviceTypes](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DEVICETYPES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Incidents].[Incidents]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Incidents].[Incidents](
	[ID] [int] NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[Type] [int] NOT NULL,
	[Subject] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Executor] [int] NOT NULL,
	[Service] [int] NOT NULL,
	[Department] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Deadline] [datetime2](7) NOT NULL,
	[StartedWhen] [datetime2](7) NOT NULL,
	[CompletedWhen] [datetime2](7) NOT NULL,
	[Result] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_INCIDENTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [AK1_Incidents] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Incidents].[IncidentSpecification]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Incidents].[IncidentSpecification](
	[LineID] [int] NOT NULL,
	[Incident] [int] NOT NULL,
	[Device] [int] NOT NULL,
 CONSTRAINT [PK_INCIDENTSPECIFICATION] PRIMARY KEY CLUSTERED 
(
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Incidents].[IncidentStatuses]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Incidents].[IncidentStatuses](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_INCIDENTSTATUSES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Incidents].[IncidentTypes]    Script Date: 16.07.2020 0:54:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Incidents].[IncidentTypes](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_incidenttypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Incidents].[Incidents] ADD  CONSTRAINT [DF_Incidents_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Application].[SLA]  WITH CHECK ADD  CONSTRAINT [SLA_fk0] FOREIGN KEY([IncidentType])
REFERENCES [Incidents].[IncidentTypes] ([ID])
GO
ALTER TABLE [Application].[SLA] CHECK CONSTRAINT [SLA_fk0]
GO
ALTER TABLE [Application].[SLA]  WITH CHECK ADD  CONSTRAINT [SLA_fk1] FOREIGN KEY([Service])
REFERENCES [Application].[Services] ([ID])
GO
ALTER TABLE [Application].[SLA] CHECK CONSTRAINT [SLA_fk1]
GO
ALTER TABLE [Application].[UserContacts]  WITH CHECK ADD  CONSTRAINT [UserContacts_fk0] FOREIGN KEY([UserID])
REFERENCES [Application].[Users] ([ID])
GO
ALTER TABLE [Application].[UserContacts] CHECK CONSTRAINT [UserContacts_fk0]
GO
ALTER TABLE [Application].[UserContacts]  WITH CHECK ADD  CONSTRAINT [UserContacts_fk1] FOREIGN KEY([ContactType])
REFERENCES [Application].[ContactTypes] ([ID])
GO
ALTER TABLE [Application].[UserContacts] CHECK CONSTRAINT [UserContacts_fk1]
GO
ALTER TABLE [Application].[Users]  WITH CHECK ADD  CONSTRAINT [Users_fk0] FOREIGN KEY([Department])
REFERENCES [Application].[Departments] ([ID])
GO
ALTER TABLE [Application].[Users] CHECK CONSTRAINT [Users_fk0]
GO
ALTER TABLE [Devices].[DeviceOwners]  WITH CHECK ADD  CONSTRAINT [DeviceOwners_fk0] FOREIGN KEY([Deivce])
REFERENCES [Devices].[Devices] ([ID])
GO
ALTER TABLE [Devices].[DeviceOwners] CHECK CONSTRAINT [DeviceOwners_fk0]
GO
ALTER TABLE [Devices].[DeviceOwners]  WITH CHECK ADD  CONSTRAINT [DeviceOwners_fk1] FOREIGN KEY([UserID])
REFERENCES [Application].[Users] ([ID])
GO
ALTER TABLE [Devices].[DeviceOwners] CHECK CONSTRAINT [DeviceOwners_fk1]
GO
ALTER TABLE [Devices].[Devices]  WITH CHECK ADD  CONSTRAINT [Devices_fk0] FOREIGN KEY([DeviceType])
REFERENCES [Devices].[DeviceTypes] ([ID])
GO
ALTER TABLE [Devices].[Devices] CHECK CONSTRAINT [Devices_fk0]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk0] FOREIGN KEY([UserID])
REFERENCES [Application].[Users] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk0]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk1] FOREIGN KEY([Executor])
REFERENCES [Application].[Users] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk1]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk2] FOREIGN KEY([Service])
REFERENCES [Application].[Services] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk2]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk3] FOREIGN KEY([Department])
REFERENCES [Application].[Departments] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk3]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk4] FOREIGN KEY([Status])
REFERENCES [Incidents].[IncidentStatuses] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk4]
GO
ALTER TABLE [Incidents].[Incidents]  WITH CHECK ADD  CONSTRAINT [Incidents_fk5] FOREIGN KEY([Type])
REFERENCES [Incidents].[IncidentTypes] ([ID])
GO
ALTER TABLE [Incidents].[Incidents] CHECK CONSTRAINT [Incidents_fk5]
GO
ALTER TABLE [Incidents].[IncidentSpecification]  WITH CHECK ADD  CONSTRAINT [IncidentSpecification_fk0] FOREIGN KEY([Incident])
REFERENCES [Incidents].[Incidents] ([ID])
GO
ALTER TABLE [Incidents].[IncidentSpecification] CHECK CONSTRAINT [IncidentSpecification_fk0]
GO
ALTER TABLE [Incidents].[IncidentSpecification]  WITH CHECK ADD  CONSTRAINT [IncidentSpecification_fk1] FOREIGN KEY([Device])
REFERENCES [Devices].[Devices] ([ID])
GO
ALTER TABLE [Incidents].[IncidentSpecification] CHECK CONSTRAINT [IncidentSpecification_fk1]
GO
